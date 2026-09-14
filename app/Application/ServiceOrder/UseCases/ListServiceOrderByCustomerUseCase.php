<?php

namespace App\Application\ServiceOrder\UseCases;

use App\Application\ServiceOrder\DTOs\ListServiceOrderDTO;
use App\Domain\ServiceOrder\Interfaces\ServiceOrderRepositoryInterface;

class ListServiceOrderByCustomerUseCase
{
    public function __construct(
        private ServiceOrderRepositoryInterface $repository
    ) {}

    public function execute(ListServiceOrderDTO $dto, string $customerId): array
    {
        $perPage = $dto->perPage;

        if ($perPage <= 0) {
            $perPage = 10;
        }

        return $this->repository->paginateByCustomer($dto->page, $perPage, $customerId);
    }
}
